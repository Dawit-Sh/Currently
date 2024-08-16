#!/bin/bash

# Function to calculate the percentage of the book read
calculate_percentage() {
    echo "Enter the total number of pages in the book:"
    read total_pages

    # Validate total pages input
    if ! [[ "$total_pages" =~ ^[0-9]+$ ]] || [ "$total_pages" -le 0 ]; then
        echo "Invalid input. Total pages must be a positive integer."
        exit 1
    fi

    echo "Enter the current page number:"
    read current_page

    # Validate current page input
    if ! [[ "$current_page" =~ ^[0-9]+$ ]] || [ "$current_page" -lt 0 ] || [ "$current_page" -gt "$total_pages" ]; then
        echo "Invalid input. Current page must be a non-negative integer and cannot exceed total pages."
        exit 1
    fi

    # Calculate percentage
    percentage=$(echo "scale=2; ($current_page / $total_pages) * 100" | bc)
    
    # Display the result
    echo "You have read $percentage% of the book."
}

# Run the function
calculate_percentage
