# Documentation

## Solution Strategy

**This solution tries to minimize the effort to achive the objective of this test.**

Based on the test's senario, the created K8S cluster needs the following components installed after the cluster creation process:
- ingress-nginx
- cert-manager (For easy Let'sEncrypt certificate generation for ingress resources.)
- ArgoCD
- local-path-provisioner (extra - for dynamic pvc provisioning)

As Kubespray allows us to enable all these addons in, they are enabled in Kubespray's values so after the cluster creation, they will be installed on the target cluster.

The Helm Chart is created with only the required dependencies (`bitnami/wordpress` and `bitnami/phpmyadmin` charts as helm dependency) and some customizations in the default values of these charts to fulfill the requirements. [Chart documentation](https://github.com/ikermani/devops-test/charts/wp-pma/README.md) gives more detailed description about the customizations made to the default values to solve the problem of this test.

When the chart get pushed to the repository, the Github actions runner builds all charts under the `charts/` directory and creates chart release and helm repoository file (`index.yaml`). After all they all get released at Github releases and Github pages (`gh-pages` branch).

So when a new chart is released ArgoCD fetches the new chart and deploys it on the target namespace.

### bootstrap.sh
The `bootstrap.sh` is a script that executes the following procedure:

1. Fetching Kubespray from Github and extract it.
2. Install requirements to run ansible.
3. Generate the invnetroy varaibles using Kubespray's helper script
4. Changing some of default values to meet the requirements of this test. (eg. enabling ingress-nginx, argocd and etc.)
5. Creating the cluster using `ansible-playbook` command.
6. Creating `cluster-issuer.yaml` and `application.yaml` resources and waiting or the deployment to get to the ready state.

In order to run this script, just run the following command:
```bash
bash bootstrap.sh
```

### cluster-issuer.yaml
This file contains cert-manager's `ClusterIsser` resource that is responsible for issuing Let's Encrypt valid certificate for ingress objects that use this issuer in their annotations.

### application.yaml
It contains `Application` resource of ArgoCD which is configured in a way that tracks the helm chart deployed in github chart repository and deploys it in `test` namespace.






# DevOps Test

## Must do:

1. [GitOps Principles](https://en.wikipedia.org/wiki/DevOps#GitOps) [Explainer Video](https://www.youtube.com/watch?v=f5EpcWp0THw)
2. Document your solution

## Requirements and Step


1. Setup a Kubernetes cluster on a single node (CP + Worker) using Kubespray
2. Create a Helm Chart that bootstraps a WordPress application with MySQL and PhpMyAdmin ingress

- WordPress Ingress
- MySQL Deployment
- PhpMyAdmin has an Ingress

## Nice to do

1. Create a Terraform script for the Kubernetes cluster
2. Create a CI/CD Azure Pipeline in YAML format in the root project.

## Delivery
1. You will be given a VPS running Ubuntu 22, you must be able to deploy with the single command line on this VPS.
2. You must plan your code in such a way that if we erase the VPS and start over, we must arrive at the same state that you intended.
3. Must have a single execution script/file that we can bootstrap and review your result in a clean Ubuntu server in our environment
4. Clone/copy this repository into a new GitHub repository and add your result, then share the result with user: `mason-chase` on GitHub in private mode.
5. We must be able to navigate to `https://candidate-name.maxtld.dev/dbadmin` and observe PhpMyAdmin UI and it must work
6. WordPress must be available at `https://candidate-name.maxtld.dev/wordpress`
