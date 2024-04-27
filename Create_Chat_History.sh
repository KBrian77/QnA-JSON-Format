#!/bin/bash
# This script uses a file with Questions in it and asks each question, saving question and answer in json format for ChatNBX (Tune Chat API) fine-tuning
# Uses questions.txt file for questions and appends to chat_hist.json
# Resumes asking questions where it left off
# Type 'e' to exit

# Initialize variables
question_file="questions.txt"
output_file="chat_hist.json"
questions=()

# Check if chat history file exists, if not, create it
if [ ! -f "$output_file" ]; then
    echo -e "{\n  \"messages\": []\n}" > "$output_file"
fi

# Read questions from file
while IFS= read -r line; do
    questions+=("$line")
done < "$question_file"

# Start building the JSON array
json_array="{\n  \"messages\": ["

# Loop through questions
for question in "${questions[@]}"; do
    # Prompt user with the question
    echo "$question"
    # Read user's answer
    read -r answer
    # Check if user wants to exit
    if [ "$answer" = "e" ]; then
        break
    fi
    # Format question and answer in JSON
    json_array+="\n    {\n      \"role\": \"user\",\n      \"content\": \"$question\"\n    },\n    {\n      \"role\": \"system\",\n      \"content\": \"$answer\"\n    },"
done

# Close the JSON array
json_array+="\n  ]\n}"

# Append JSON array to output file
echo -e "$json_array" >> "$output_file"

echo "Chat history updated in $output_file
