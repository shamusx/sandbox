
# Replace 'old_string' with 'new_value'
string_to_replace="ADMIN_USERNAME"
new_value="{{ TSB_USERNAME }}"

# Set the file path pattern(s) you want to apply the command to
file_pattern=$1  # Adjust as needed

# Apply the sed command
for file in $(find "$file_pattern" -type f); do
    echo "Updating file: $file from $string_to_replace to $new_value"
    sed -i "s/$string_to_replace/$new_value/g" "$file"
done