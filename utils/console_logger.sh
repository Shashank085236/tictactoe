#! /bin/bash

RED='\033[0;31m';
GREEN='\033[0;32m';
YELLOW='\033[0;33m';
NC='\033[0m';

function warn {
	${date} printf "${YELLOW}$1${NCi}\n";
}

function error {
	${date} printf "${RED}$1${NC}\n";
}

function log {
	${date} printf "${GREEN}$1${NC}\n";
}
