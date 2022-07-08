qemu-img create sortix.raw 1G 
qemu-system-x86_64 -enable-kvm -m 1024 -vga std -cdrom sortix/sortix.iso #\
#                   -drive file=sortix.raw,format=raw
