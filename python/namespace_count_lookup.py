import requests
import os
import sys
import argparse

# Config
HOSTNAME = os.getenv("HOSTNAME", "tsb.tfc.dogfood.sandbox.tetrate.io")
ORG = os.getenv("ORG", "tfc")
TSB_TOKEN = os.getenv("TSB_TOKEN")

if not TSB_TOKEN:
    print("Missing TSB_TOKEN environment variable", file=sys.stderr)
    sys.exit(1)

# Setup session with common headers
session = requests.Session()
session.verify = False
session.headers.update({
    "Authorization": f"Bearer {TSB_TOKEN}",
    "Content-Type": "application/json"
})

def get_tenants():
    """Fetch all tenants in the organization."""
    response = session.get(f"https://{HOSTNAME}/v2/organizations/{ORG}/tenants")
    response.raise_for_status()
    return response.json().get('tenants', [])

def get_workspaces(tenant_fqn):
    """Fetch all workspaces for a given tenant."""
    response = session.get(f"https://{HOSTNAME}/v2/{tenant_fqn}/workspaces")
    response.raise_for_status()
    return response.json().get('workspaces', [])

def get_traffic_groups(workspace_fqn):
    """Fetch all traffic groups for a given workspace."""
    try:
        response = session.get(f"https://{HOSTNAME}/v2/{workspace_fqn}/trafficgroups")
        response.raise_for_status()
        return response.json().get('groups', [])
    except Exception:
        return []

def get_gateway_groups(workspace_fqn):
    """Fetch all gateway groups for a given workspace."""
    try:
        response = session.get(f"https://{HOSTNAME}/v2/{workspace_fqn}/gatewaygroups")
        response.raise_for_status()
        return response.json().get('groups', [])
    except Exception:
        return []

def main():
    parser = argparse.ArgumentParser(description='Review number of namespaces for each workspace and its groups.')
    parser.add_argument('--debug', action='store_true', help='Enable debug output')
    args = parser.parse_args()

    results = []
    total_traffic_groups = 0
    total_gateway_groups = 0
    
    try:
        for tenant in get_tenants():
            tenant_name = tenant['fqn'].split('/')[-1]
            if args.debug:
                print(f"Processing tenant: {tenant_name}")
            
            for workspace in get_workspaces(tenant['fqn']):
                try:
                    workspace_fqn = workspace['fqn']
                    workspace_name = workspace_fqn.split('/')[-1]
                    selectors = workspace.get('namespaceSelector', {})
                    
                    workspace_ns_count = 0
                    if isinstance(selectors, dict) and 'names' in selectors:
                        workspace_ns_count = len(selectors['names'])
                    
                    # Get traffic groups and their namespace counts
                    traffic_groups = get_traffic_groups(workspace_fqn)
                    traffic_group_ns_count = 0
                    for tg in traffic_groups:
                        tg_selectors = tg.get('namespaceSelector', {})
                        if isinstance(tg_selectors, dict) and 'names' in tg_selectors:
                            traffic_group_ns_count += len(tg_selectors['names'])
                    
                    # Get gateway groups and their namespace counts
                    gateway_groups = get_gateway_groups(workspace_fqn)
                    gateway_group_ns_count = 0
                    for gg in gateway_groups:
                        gg_selectors = gg.get('namespaceSelector', {})
                        if isinstance(gg_selectors, dict) and 'names' in gg_selectors:
                            gateway_group_ns_count += len(gg_selectors['names'])
                    
                    total_traffic_groups += len(traffic_groups)
                    total_gateway_groups += len(gateway_groups)
                    
                    results.append({
                        'tenant': tenant_name,
                        'workspace': workspace_name,
                        'workspace_ns': workspace_ns_count,
                        'traffic_groups': len(traffic_groups),
                        'traffic_group_ns': traffic_group_ns_count,
                        'gateway_groups': len(gateway_groups),
                        'gateway_group_ns': gateway_group_ns_count,
                        'total_ns': workspace_ns_count + traffic_group_ns_count + gateway_group_ns_count
                    })
                    
                    if args.debug:
                        print(f"  Workspace: {workspace_name}")
                        print(f"    Workspace namespaces: {workspace_ns_count}")
                        print(f"    Traffic groups: {len(traffic_groups)} (namespaces: {traffic_group_ns_count})")
                        print(f"    Gateway groups: {len(gateway_groups)} (namespaces: {gateway_group_ns_count})")
                        
                except Exception as e:
                    print(f"Error processing {workspace['fqn']}: {str(e)}", file=sys.stderr)
        
        # Sort by total namespace count (descending) then by workspace name
        results.sort(key=lambda x: (-x['total_ns'], x['workspace']))
        
        print("\nNamespace count per workspace and groups:\n")
        print(f"{'Tenant':<15} {'Workspace':<25} {'WS NS':>7} {'TG':>5} {'TG NS':>7} {'GG':>5} {'GG NS':>7} {'Total NS':>10}")
        print("-" * 92)
        
        for item in results:
            print(f"{item['tenant']:<15} {item['workspace']:<25} {item['workspace_ns']:>7} "
                  f"{item['traffic_groups']:>5} {item['traffic_group_ns']:>7} "
                  f"{item['gateway_groups']:>5} {item['gateway_group_ns']:>7} {item['total_ns']:>10}")
        
        # Summary statistics
        total_workspaces = len(results)
        total_workspace_ns = sum(item['workspace_ns'] for item in results)
        total_tg_ns = sum(item['traffic_group_ns'] for item in results)
        total_gg_ns = sum(item['gateway_group_ns'] for item in results)
        total_all_ns = sum(item['total_ns'] for item in results)
        total_groups = total_traffic_groups + total_gateway_groups
        
        print("\n" + "=" * 92)
        print("SUMMARY")
        print("=" * 92)
        print(f"Total workspaces: {total_workspaces}")
        print(f"Total traffic groups: {total_traffic_groups}")
        print(f"Total gateway groups: {total_gateway_groups}")
        print(f"Total groups (traffic + gateway): {total_groups}")
        print(f"\nTotal workspace namespaces: {total_workspace_ns}")
        print(f"Total traffic group namespaces: {total_tg_ns}")
        print(f"Total gateway group namespaces: {total_gg_ns}")
        print(f"Total namespaces (all sources): {total_all_ns}")
            
    except Exception as e:
        print(f"An error occurred: {str(e)}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
