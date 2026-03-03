# Function to check if a command exists
check_command() {
    if ! command -v $1 &> /dev/null
    then
        echo "Error: $1 is not installed." >&2
        exit 1
    fi
}

# Check for required dependencies
check_command skopeo
check_command aws
check_command helm

USERNAME="<userid>"
PASSWORD="<password>"
REGISTRY_URL="<registry_url>"
SOURCE_REGISTRY_URL="<source_registry_url>"
HELM_VERSION="1.11.0-internal-rc1"
IMAGE_LIST="managementplane/images.txt"

REGION="us-east-2"
AWS_ACCOUNT_ID="<aws_acct>"

# Login to Docker registry
skopeo login -u $USERNAME -p $PASSWORD $REGISTRY_URL
aws ecr get-login-password --region $REGION | skopeo login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Pull and extract Helm chart
helm pull tetrate-tsb-helm/managementplane --version $HELM_VERSION --devel
tar zxvf managementplane-$HELM_VERSION.tgz

# Copy images using skopeo
for IMAGE in $(cut -d/ -f2- $IMAGE_LIST)
do
skopeo copy \
    docker://$SOURCE_REGISTRY_URL/$IMAGE \
    docker://$REGISTRY_URL/$IMAGE &
done
