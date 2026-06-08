# Solo 2 4150: Tip Calculator

This is a Flutter tip calculator app that takes a bill amount, tip percentage (via slider), and number of people as inputs, validates them, and calculates the tip amount, total, and per-person split. 

## Getting Started

To run it, clone the repo, cd into the project folder, and run flutter run. The app cycles through 5 background colors (pink #FFB3BA, orange #FFD9A0, yellow #FFFFBC, green #B5EAD7, deep blue #4A6FA5) when the user taps any empty area of the screen. I added text to inidcate this to the user. Foreground color is calculated using computeLuminance() the 4 light pastels return black text and the deep blue returns white text, keeping everything readable. This same logic applies to the scaffold, app bar, and all content. 

Sample inputs: bill $45.00, tip 20%, 3 people calculated as a tip of $9.00, total $54.00 and per person $18.00. 

## Edge case: 
entering 0 or a negative bill amount shows a validation error and blocks the calculation. Entering 0 people also throws a validation error since dividing by zero is blocked before it can cause a crash.
