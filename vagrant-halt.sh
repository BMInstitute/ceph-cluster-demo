#!/bin/sh -e

cd ceph-client && vagrant halt
cd ..

cd ceph-deploy && vagrant halt
cd ..

cd ceph-n1 && vagrant halt
cd ..

cd ceph-n2 && vagrant halt
cd ..

cd ceph-n3 && vagrant halt
cd ..

