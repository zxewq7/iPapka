#!/bin/sh

mogenerator --base-class BWOrderedManagedObject --template-path=mogenerator -m Data.xcdatamodeld/Data.xcdatamodel -O Classes/DataModel
