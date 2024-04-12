#!/bin/bash

psql -h pg -d studs -f  ~/RSHD/script.sql 2>&1 | sed 's|.*NOTICE:  ||g'