publish:
	scp *.md images/* c10l@prose.sh:/
.PHONY: publish

ssh:
	ssh c10l@prose.sh
.PHONY: ssh

imgs:
	ssh c10l@imgs.sh
.PHONY: ssh
