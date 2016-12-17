#!/bin/sh -e

cd ceph-client && vagrant up
cd ..

cd ceph-deploy && vagrant up
cd ..

cd ceph-n1 && vagrant up
cd ..

cd ceph-n2 && vagrant up
cd ..

cd ceph-n3 && vagrant up
cd ..

