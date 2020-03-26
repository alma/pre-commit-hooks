Alma pre-commit-hooks
=====================

Some Alma hooks for pre-commit.

See also: https://github.com/pre-commit/pre-commit


### Using pre-commit-hooks with pre-commit

Add this to your `.pre-commit-config.yaml`

```yaml
-   repo: https://github.com/alma/pre-commit-hooks
    rev: 1.0.0
    hooks:
    - id: check-file-change
      files: "^test.*.sh$"
      args:
        - --check
        - test_backend.sh:eacaec4b8c4665dfce2d0e082acd0d39787457da
        - test_integration.sh:fc28748b80c051079ef215c7e1df831d28d080e3
        - test_jobs.sh:6b2b56fa7c4a2856b6fc4c1b4fd5378560b70d34
        - test_laparisienne_mock.sh:fe93f2ec97505f9857bb38177c84e5ecd5d00696
        - test_laparisienne.sh:7c739a236019095f8994c787d05255fac4f560f2
        - test_local_storage.sh:eb46fbfb216407fe4dc539e71a658e6c2e629a4f
        - test_psp_real_stripe.sh:41c58aaa08faec4e37c3b482b4a3bc3df251fa26
        - test_psp_stripe_mock.sh:f8b59a70afa78a09c06125a626fa9b7ec4e04533
        - test_selenium.sh:79bc2bb18e491fff992d24bc150c7ede60667ad4
        - test_servers.sh:097f87774738ad21e150d018d94dc2a328004e7f
        - test.sh:0aa6bce453ccf4a907bd5211a0834225a42def6e
        - test_shopify.sh:df47811c79a2f23413ecc40a55f77ea783a9a487
        - test_storage.sh:a36add7608d07809a3040b0a382547a77f6aaf51
        - --
```

### Hooks available

#### `check-file-change

Make sure files didn't change.
You must provide list of target files with their expected checksum in a given algorithm. (Default is sha1)
You can change the algorithm with the ``--algorithm=sha256`` option.
