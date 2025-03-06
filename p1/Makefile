VAGRANT_UP = vagrant up
VAGRANT_HALT = vagrant halt
VAGRANT_DESTROY = vagrant destroy -f
VAGRANT_STATUS = vagrant status

# Default target
.PHONY: all
all: up

# Bring up the Vagrant VMs
.PHONY: up
up:
	$(VAGRANT_UP)

# Halt the Vagrant VMs
.PHONY: halt
halt:
	$(VAGRANT_HALT)

# Destroy the Vagrant VMs
.PHONY: destroy
destroy:
	$(VAGRANT_DESTROY)

# Check the status of the Vagrant VMs
.PHONY: status
status:
	$(VAGRANT_STATUS)
