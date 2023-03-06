#!/bin/sh

SYSTEMDIR=$HOME/rootfs/system
OPENSSH=$(basename $PWD)

cat >a.py <<EOF

a="$OPENSSH"
print(a[0:7])

EOF

openssh=$(python3 a.py)
rm a.py

    if [ ! $openssh = "openssh" ]; then
      echo "must in openssh directory"
      exit 1
     fi

    ./configure \
    --bindir=/usr/bin \
  --sbindir=/usr/sbin \
  --libexecdir=/usr/libexec \
  --sysconfdir=/etc/ssh \
  --localstatedir=/var \
  --runstatedir=/run \
  --libdir=/usr/lib \
  --includedir=/usr/include

    if [ ! "$?" = 0 ]; then
        echo
        echo "configure openssh error!"
        echo
        exit 1
    fi

#LDFLAGS
sed '/^LDFLAGS=/aLDFLAGS += -s' Makefile >mm
mv mm Makefile


    make -j 8

    if [ ! "$?" = 0 ]; then
        echo
        echo "make openssh error!"
        echo
        exit 2
    fi

cat >openssh-install <<EOF
prefix=/usr/local
exec_prefix=\${prefix}
bindir=/usr/bin
sbindir=/usr/sbin
libexecdir=/usr/libexec
sysconfdir=/etc/ssh
sysstart=/etc/init.d
piddir=/var/run
srcdir=.
top_srcdir=.

DESTDIR=

SSH_PROGRAM=/usr/bin/ssh
ASKPASS_PROGRAM=\$(libexecdir)/ssh-askpass
SFTP_SERVER=\$(libexecdir)/sftp-server
SSH_KEYSIGN=\$(libexecdir)/ssh-keysign
SSH_PKCS11_HELPER=\$(libexecdir)/ssh-pkcs11-helper
SSH_SK_HELPER=\$(libexecdir)/ssh-sk-helper
PRIVSEP_PATH=/var/empty
SSH_PRIVSEP_USER=sshd
STRIP_OPT=-s
TEST_SHELL=sh
MKDIR_P=mkdir -p
INSTALL=install

all: install

install: install-files install-sysconf host-key-force

install-files:
	\$(MKDIR_P) \$(DESTDIR)\$(bindir)
	\$(MKDIR_P) \$(DESTDIR)\$(sbindir)
	\$(MKDIR_P) \$(DESTDIR)\$(libexecdir)
	\$(MKDIR_P) \$(DESTDIR)\$(sysstart)
	\$(MKDIR_P) -m 0755 \$(DESTDIR)\$(PRIVSEP_PATH)
	\$(INSTALL) -m 0755 \$(STRIP_OPT) ssh\$(EXEEXT) \$(DESTDIR)\$(bindir)/ssh\$(EXEEXT)
	\$(INSTALL) -m 0755 \$(STRIP_OPT) scp\$(EXEEXT) \$(DESTDIR)\$(bindir)/scp\$(EXEEXT)
	\$(INSTALL) -m 0755 \$(STRIP_OPT) ssh-add\$(EXEEXT) \$(DESTDIR)\$(bindir)/ssh-add\$(EXEEXT)
	\$(INSTALL) -m 0755 \$(STRIP_OPT) ssh-agent\$(EXEEXT) \$(DESTDIR)\$(bindir)/ssh-agent\$(EXEEXT)
	\$(INSTALL) -m 0755 \$(STRIP_OPT) ssh-keygen\$(EXEEXT) \$(DESTDIR)\$(bindir)/ssh-keygen\$(EXEEXT)
	\$(INSTALL) -m 0755 \$(STRIP_OPT) ssh-keyscan\$(EXEEXT) \$(DESTDIR)\$(bindir)/ssh-keyscan\$(EXEEXT)
	\$(INSTALL) -m 0755 \$(STRIP_OPT) sshd\$(EXEEXT) \$(DESTDIR)\$(sbindir)/sshd\$(EXEEXT)
	\$(INSTALL) -m 4711 \$(STRIP_OPT) ssh-keysign\$(EXEEXT) \$(DESTDIR)\$(SSH_KEYSIGN)\$(EXEEXT)
	\$(INSTALL) -m 0755 \$(STRIP_OPT) ssh-pkcs11-helper\$(EXEEXT) \$(DESTDIR)\$(SSH_PKCS11_HELPER)\$(EXEEXT)
	\$(INSTALL) -m 0755 \$(STRIP_OPT) ssh-sk-helper\$(EXEEXT) \$(DESTDIR)\$(SSH_SK_HELPER)\$(EXEEXT)
	\$(INSTALL) -m 0755 \$(STRIP_OPT) sftp\$(EXEEXT) \$(DESTDIR)\$(bindir)/sftp\$(EXEEXT)
	\$(INSTALL) -m 0755 \$(STRIP_OPT) sftp-server\$(EXEEXT) \$(DESTDIR)\$(SFTP_SERVER)\$(EXEEXT)

install-sysconf:
	\$(MKDIR_P) \$(DESTDIR)\$(sysconfdir)
	@if [ ! -f \$(DESTDIR)\$(sysconfdir)/ssh_config ]; then \
		\$(INSTALL) -m 644 ssh_config.out \$(DESTDIR)\$(sysconfdir)/ssh_config; \
	else \
		echo "\$(DESTDIR)\$(sysconfdir)/ssh_config already exists, install will not overwrite"; \
	fi
	@if [ ! -f \$(DESTDIR)\$(sysconfdir)/sshd_config ]; then \
		\$(INSTALL) -m 644 sshd_config.out \$(DESTDIR)\$(sysconfdir)/sshd_config; \
	else \
		echo "\$(DESTDIR)\$(sysconfdir)/sshd_config already exists, install will not overwrite"; \
	fi
	@if [ ! -f \$(DESTDIR)\$(sysconfdir)/moduli ]; then \
		if [ -f \$(DESTDIR)\$(sysconfdir)/primes ]; then \
			echo "moving \$(DESTDIR)\$(sysconfdir)/primes to \$(DESTDIR)\$(sysconfdir)/moduli"; \
			mv "\$(DESTDIR)\$(sysconfdir)/primes" "\$(DESTDIR)\$(sysconfdir)/moduli"; \
		else \
			\$(INSTALL) -m 644 moduli.out \$(DESTDIR)\$(sysconfdir)/moduli; \
		fi ; \
	else \
		echo "\$(DESTDIR)\$(sysconfdir)/moduli already exists, install will not overwrite"; \
	fi

host-key-force: ssh-keygen\$(EXEEXT) ssh\$(EXEEXT)
	./ssh-keygen -t dsa -f \$(DESTDIR)\$(sysconfdir)/ssh_host_dsa_key -N ""
	./ssh-keygen -t rsa -f \$(DESTDIR)\$(sysconfdir)/ssh_host_rsa_key -N ""
	./ssh-keygen -t ed25519 -f \$(DESTDIR)\$(sysconfdir)/ssh_host_ed25519_key -N ""
	if ./ssh -Q key | grep ecdsa >/dev/null ; then \
		./ssh-keygen -t ecdsa -f \$(DESTDIR)\$(sysconfdir)/ssh_host_ecdsa_key -N ""; \
	fi

uninstallall:	uninstall
	-rm -f \$(DESTDIR)\$(sysconfdir)/ssh_config
	-rm -f \$(DESTDIR)\$(sysconfdir)/sshd_config
	-rmdir \$(DESTDIR)\$(sysconfdir)
	-rmdir \$(DESTDIR)\$(bindir)
	-rmdir \$(DESTDIR)\$(sbindir)
	-rmdir \$(DESTDIR)\$(libexecdir)

uninstall:
	-rm -f \$(DESTDIR)\$(bindir)/ssh\$(EXEEXT)
	-rm -f \$(DESTDIR)\$(bindir)/scp\$(EXEEXT)
	-rm -f \$(DESTDIR)\$(bindir)/ssh-add\$(EXEEXT)
	-rm -f \$(DESTDIR)\$(bindir)/ssh-agent\$(EXEEXT)
	-rm -f \$(DESTDIR)\$(bindir)/ssh-keygen\$(EXEEXT)
	-rm -f \$(DESTDIR)\$(bindir)/ssh-keyscan\$(EXEEXT)
	-rm -f \$(DESTDIR)\$(bindir)/sftp\$(EXEEXT)
	-rm -f \$(DESTDIR)\$(sbindir)/sshd\$(EXEEXT)
	-rm -r \$(DESTDIR)\$(SFTP_SERVER)\$(EXEEXT)
	-rm -f \$(DESTDIR)\$(SSH_KEYSIGN)\$(EXEEXT)
	-rm -f \$(DESTDIR)\$(SSH_PKCS11_HELPER)\$(EXEEXT)
	-rm -f \$(DESTDIR)\$(SSH_SK_HELPER)\$(EXEEXT)

EOF

sudo rm -fr $SYSTEMDIR/etc/ssh

sudo make DESTDIR=$SYSTEMDIR -f openssh-install

    if [ ! "$?" = 0 ]; then
        echo
        echo "install openssh error!"
        echo
        exit 3
    fi

rm openssh-install


cat >S50ssh <<EOF

#!/bin/sh
#
# Starts openssh sshd.
#

# Make sure the ssh-keygen progam exists
# [ -f /usr/bin/ssh-keygen ] || exit 0

# Check for the ssh RSA key
#if [ ! -f /etc/ssh/ssh_rsa_host_key ] ; then
#	echo Generating RSA Key...
#	/usr/bin/ssh-keygen -t rsa -f /etc/ssh/ssh_rsa_host_key
#fi

# Check for the ssh DSS key
#if [ ! -f /etc/ssh/ssh_dss_host_key ] ; then
#	echo Generating DSS Key...
#	/usr/bin/ssh-keygen -t dss -f /etc/ssh/ssh_dss_host_key
#fi

    umask 022

    start() {
 	    echo -n "Starting sshd: "
	    start-stop-daemon --start --quiet --pidfile /var/run/sshd.pid --exec /usr/sbin/sshd
	    echo "OK"
    }

    stop() {
	    echo -n "Stopping sshd: "
	    start-stop-daemon --stop --quiet --pidfile /var/run/sshd.pid
	    echo "OK"
    }

    restart() {
	    stop
	    start
    }

    case "\$1" in
    start)
  	    start
	    ;;
    stop)
  	    stop
	    ;;
    restart|reload)
  	    restart
	    ;;
    *)
	    echo \$"Usage: \$0 {start|stop|restart}"
	    exit 1
    esac

    exit \$?

EOF

cat > opt.sh <<EOF

    sudo chmod +x S50ssh
    sudo chown 0.0 S50ssh
    sudo mv S50ssh $SYSTEMDIR/etc/init.d
    echo "#Start ssh" >> $SYSTEMDIR/opt/bootlocal.sh
    echo "/etc/init.d/S50ssh start" >> $SYSTEMDIR/opt/bootlocal.sh
    echo " " >> $SYSTEMDIR/opt/bootlocal.sh
	sudo echo "KexAlgorithms=+diffie-hellman-group14-sha1" >>  $SYSTEMDIR/etc/ssh/ssh_config

EOF

    chmod +x opt.sh
    sudo ./opt.sh

    echo
    echo "$?"
    echo
    echo "install openssh in $SYSTEMDIR --> ok"
    echo

    rm opt.sh
    echo
    echo "make openssh Done!"
    echo

    exit 0

