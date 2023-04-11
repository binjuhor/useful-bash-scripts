#/bin/bash
work_dir=/opt/easyengine/sites/binjuhor/
cd $work_dir

git pull origin master


filename="$work_dir/README.md"
search_pattern="([0-9]+\.[0-9]+ days)"

if matched_line=$(grep -oE "$search_pattern" "$filename"); then

	# Extract the number from the matching line using command substitution
    number=$(echo "$matched_line" | grep -oE '[0-9]+\.[0-9]+')
	pure_number=$(echo "$number" | tr -d '.')

	# Increment the number by 1 using arithmetic expansion
    incremented_number=$(echo "$pure_number + 1" | bc)
	formatted_number=$(echo "$incremented_number" | sed -E ':L;s=\b([0-9]+)([0-9]{3})\b=\1.\2=g;t L')

	# Replaced the number of found
	sed -i "s/$number/$formatted_number/g" "$filename"
fi

git add .
git commit -m "chore: update readme.md file $(date +%d/%m/%Y)"
git push origin master
