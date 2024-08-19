publish:
	scp blog/* images/* c10l@prose.sh:/
.PHONY: publish

ssh:
	ssh c10l@pico.sh
.PHONY: ssh

imgs:
	ssh c10l@imgs.sh
.PHONY: ssh
