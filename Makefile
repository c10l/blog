publish:
	scp *.md images/* c10l@prose.sh:/
.PHONY: publish

ssh:
	ssh c10l@prose.sh
.PHONY: ssh
