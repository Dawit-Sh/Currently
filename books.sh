#!/bin/bash

# Path to the books.json file
BOOKS_JSON="books.json"

# Function to check if jq is installed
check_jq_installed() {
    if ! command -v jq &> /dev/null; then
        echo "jq is not installed. Please install jq to use this script."
        exit 1
    fi
}

# Function to add a new book
add_book() {
    echo "Enter the book title:"
    read title
    echo "Enter the author's name:"
    read author
    echo "Enter the genre:"
    read genre
    echo "Enter the image URL (optional, press Enter to skip):"
    read image
    echo "Enter the book URL (optional, press Enter to skip):"
    read url
    echo "Enter the current page you are on (0 if you want to start from scratch):"
    read progress

    # Determine the next book item number
    book_item=$(jq '.currentlyReading | length + 1' "$BOOKS_JSON")

    # Create a new book object
    new_book=$(jq -n --arg title "$title" --arg author "$author" --arg genre "$genre" --arg image "$image" --arg url "$url" --argjson progress "$progress" --argjson book "$book_item" '{
        title: $title,
        author: $author,
        genre: $genre,
        image: $image,
        url: $url,
        progress: $progress,
        book: $book
    }')

    # Add the new book to the books.json file
    jq --argjson new_book "$new_book" '.currentlyReading += [$new_book]' "$BOOKS_JSON" > tmp.$$.json && mv tmp.$$.json "$BOOKS_JSON"

    echo "Book added successfully!"
}

# Function to remove a book
remove_book() {
    echo "Enter the book item number to remove:"
    read item_number

    # Remove the book with the given item number
    jq --argjson item_number "$item_number" 'del(.currentlyReading[] | select(.book == $item_number))' "$BOOKS_JSON" > tmp.$$.json && mv tmp.$$.json "$BOOKS_JSON"

    echo "Book removed successfully!"
}

# Function to update the progress of a book
update_progress() {
    echo "Enter the book item number to update:"
    read item_number

    # Check if the book exists
    book=$(jq --argjson item_number "$item_number" '.currentlyReading[] | select(.book == $item_number)' "$BOOKS_JSON")
    if [ -z "$book" ]; then
        echo "No book found with the given item number!"
        return
    fi

    echo "Current details of the book:"
    echo "$book" | jq

    echo "Enter the new progress (as a percentage, e.g., 50):"
    read progress

    # Update the progress
    jq --argjson item_number "$item_number" --argjson progress "$progress" '(.currentlyReading[] | select(.book == $item_number) | .progress) |= $progress' "$BOOKS_JSON" > tmp.$$.json && mv tmp.$$.json "$BOOKS_JSON"

    echo "Book progress updated successfully!"
}

# Main menu
main_menu() {
    echo "What would you like to do?"
    echo "1. Add a new book"
    echo "2. Remove an existing book"
    echo "3. Update the progress of a book"
    echo "4. Exit"
    read choice

    case $choice in
        1)
            add_book
            ;;
        2)
            remove_book
            ;;
        3)
            update_progress
            ;;
        4)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            main_menu
            ;;
    esac
}

# Run the script
check_jq_installed
main_menu
