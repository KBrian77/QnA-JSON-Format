#!/bin/bash
# This script uses a file with Questions in it and asks me each question and saves question and answer in json format so i can use it with ChatNBX aka tune chat api to fine tune it
# Uses questions.txt file for questions and saves chat_hist.json
# Starts questions where i exited
# e to exit
# Must have questions.txt and chat_hist.json files to use code 

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

# Read existing chat history
chat_history=$(<"$output_file")

# Start building the JSON array
json_array="{\n  \"messages\": ["

# Loop through questions
for question in "${questions[@]}"; do
    # Check if the user has answered this question already
    if [[ "$chat_history" != *"\"content\": \"$question\""* ]]; then
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
        # Update chat history
        chat_history="${chat_history%]}"
        chat_history+=",\n    {\n      \"role\": \"user\",\n      \"content\": \"$question\"\n    },\n    {\n      \"role\": \"system\",\n      \"content\": \"$answer\"\n    }\n  ]"
        # Save updated chat history
        echo -e "$chat_history" > "$output_file"
    fi
done

# Close the JSON array
json_array+="\n  ]\n}"

# Save JSON array to output file
echo -e "$json_array" > "$output_file"

echo "Chat history updated in $output_file
