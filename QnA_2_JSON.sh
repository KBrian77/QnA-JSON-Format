#!/bin/bash
USE The UPDATED New_QnA_2JSON.sh File SO JSON DATA IS FORMATTED CORRECTLY
# This script uses a file with Questions in it and asks me each question and saves question and answer in json format so i can use it with ChatNBX aka tune chat api to  fine tune it
# Uses questions.txt file that has the questions and saves chat_hist.json in json format as chat history for an AI
# Starts questions where I stopped answering questions
# e to exit
# Remember this code will not work unless you have a questions.txt file that has each questions that end with a ? mark and each question is on an its own individual line

# Initialize variables
question_file="questions.txt"
output_file="chat_hist.json"
questions=()

# Check if chat history file exists, if not, create it
if [ ! -f "$output_file" ]; then
    echo "[]" > "$output_file"
fi

# Read questions from file
while IFS= read -r line; do
    questions+=("$line")
done < "$question_file"

# Read existing chat history
chat_history=$(<"$output_file")

# Start building the JSON array
json_array="["
first_entry=true

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
        if $first_entry; then
            json_array+="\n\t\t{\n\t\t\t\"role\": \"user\",\n\t\t\t\"content\": \"$question\"\n\t\t},\n\t\t{\n\t\t\t\"role\": \"system\",\n\t\t\t\"content\": \"$answer\"\n\t\t}"
            first_entry=false
        else
            json_array+=",\n\t\t{\n\t\t\t\"role\": \"user\",\n\t\t\t\"content\": \"$question\"\n\t\t},\n\t\t{\n\t\t\t\"role\": \"system\",\n\t\t\t\"content\": \"$answer\"\n\t\t}"
        fi
        # Update chat history
        chat_history="${chat_history%,]*}, {\"role\": \"user\", \"content\": \"$question\"}, {\"role\": \"system\", \"content\": \"$answer\"}]"
        # Save updated chat history
        echo "$chat_history" > "$output_file"
    fi
done

# Close the JSON array
json_array+="\n\t]"

# Save JSON array to output file
echo -e "$json_array" > "$output_file"

echo "Chat history updated in $output_file
