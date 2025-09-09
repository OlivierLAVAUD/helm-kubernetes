#!/bin/bash
minikube stop
minikube delete
minikube start --driver=docker --cpus=2 --memory=4096

# Attendre que le cluster soit ready
kubectl cluster-info