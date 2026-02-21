.PHONY: site clean

# run php website on localhost, in a background process.
# watch the logfile for "Development Server started".
# then, use wget to download a static copy of the website.
# finally, kill the background process.
site:
	php -S localhost:8000 >> log.txt 2>&1 & export SERVER_PID=$$!; \
	tail -f -n0 log.txt | grep -qe 'started' \
	&& wget -mpckE -nH -P site localhost:8000; \
	kill $$SERVER_PID && echo "done"

clean:
	rm -r site
