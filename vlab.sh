echo Enter hatch rate
read hatch
echo Enter no of failures 
read failure
echo >> analysis.txt
echo "$(date +"%T")" >> analysis.txt
while read url
do
	for i in {1..8}
	do
		# number of users varied as 50, 100, 150...till 400
		let a="50*i"

		# flag to keep track of exceed limit
		let x="0"
		# locust cli with url read from urls.txt and hatch rate -r = 20 user per second and csv generated
		locust --host=http://$url --no-web -c $a -r $hatch --run-time 1m --csv=ex$url$i  
		echo "ex${url}${i}_requests.csv"
		cat "ex${url}${i}_requests.csv"| awk -v FS=',' '{print $4}'| head -3 | tail -n 1

		# CHECKING IF NUMNBER OF FAILURES IS GREATER THAN 40
		# If failures > 40, it is assumed that capacity is exceeded
		if [ "$(cat "ex${url}${i}_requests.csv"| awk -v FS=',' '{print $4}'| head -3 | tail -n 1)" -gt $failure ]
		then
			echo "maximum number of clients reached: $a"

			# analysis.txt contains the capacity that was identified for each url
			
			echo "${url} : ${a} " >> analysis.txt
			let x="1"
			pwd
			break
		fi
	done
	if [ "$x" -ne 1 ]
	then
		echo "${url} : >400 " >> analysis.txt
		let x="0"
	fi
	echo "$url" 
done < $1
