#/bin/bash
extract_apk_db() {
  if [ $# -ne 2 ]; then
    echo "Usage: extract_apk_db <backup_file.ab> <output_folder>"
    return 1
  fi

  backup_file="$1"
  output_folder="$2"
  temp_tar_file="temp_$1.tar"

  # Input Validation (same as before)
  if ! [ -f "$backup_file" ]; then
    echo "Error: Backup file '$backup_file' not found."
    return 1
  fi

  # Extraction to Temporary Tar File
  dd if="$backup_file" bs=1 skip=24 | python3 -c "import zlib,sys;sys.stdout.buffer.write(zlib.decompress(sys.stdin.buffer.read()))" > "$temp_tar_file"

  if [ $? -ne 0 ]; then
    echo "Error occurred during extraction."
    return 1
  fi

  # Create Output Folder
  mkdir -p "$output_folder"

  # Untar to Output Folder
  tar -xf "$temp_tar_file" -C "$output_folder"

  if [ $? -ne 0 ]; then
    echo "Error occurred while untarring."
    rm "$temp_tar_file" # Clean up
    return 1
  fi

  # Zip the Folder (Uncompressed)
  zip -0 -r "$output_folder.zip" "$output_folder"

  if [ $? -ne 0 ]; then
    echo "Error occurred while zipping."
    rm "$temp_tar_file" # Clean up
    return 1
  fi

  # Clean Up
  rm "$temp_tar_file" 

  echo "Successfully extracted, untarred, and zipped $1 to '$output_folder.zip'."
}
