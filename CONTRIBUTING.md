Fork the repository and make a local clone

Create a feature branch from the master branch

cd mongodb-enterprise-boshrelease
git checkout -b my_branch
Make changes on your branch

Deploy your version of mongodb-enterprise-boshrelease to test the changes. You can use following [guide](https://bosh.io/docs/create-release/#dev-release) how to create a dev release and how to deploy it.

Push to your fork (git push origin my_branch) and submit a pull request selecting master as the target branch