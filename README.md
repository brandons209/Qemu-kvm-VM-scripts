# Qemu-kvm-VM-scripts
[LICENSE](LICENSE)

My scripts for running my Windows 10 VM for gaming.

I ended up not using libvirt and virt-manager because I was having some issues with hard freezes. I learned a lot more going through the motions of creating my own scripts, and setting up a gaming VM in general.

The binders script contains general qemu options and also functions to bind and unbind pcie devices, mount hard disks and allocate memory through hugepages. I hope these scripts can help you in your VM adventures!

Under tools I have the general iommou group finder script that can be found in most forums, and gpu binding test just tests to make sure my gpu can be bound to vfio-pci driver, then rebound to the nvidia driver.
