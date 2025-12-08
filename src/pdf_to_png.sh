# Convert all PDF files in the param directory to SVG format using convert
dir="$1"

for pdf_file in "$dir"/*.pdf; do
    # Check if there are no PDF files
    [ -e "$pdf_file" ] || { echo "No PDF files found."; exit 1; }
    png_file="${pdf_file%.pdf}.png"
    echo "Converting $pdf_file to $png_file"
    convert -density 300 "$pdf_file" "$png_file"
done