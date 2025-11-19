#!/bin/bash
echo "Starting Jupyter Notebook..."
nohup jupyter notebook --ip=0.0.0.0 --allow-root --NotebookApp.token='' > /tmp/jupyter.log 2>&1 &
echo "Jupyter started."
