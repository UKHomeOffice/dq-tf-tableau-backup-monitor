# pylint: disable=missing-docstring, line-too-long, protected-access, E1101, C0202, E0602, W0109
import unittest
import hashlib
from runner import Runner


class TestE2E(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.snippet = """


            provider "aws" {
              region = "eu-west-2"
              skip_credentials_validation = true
            }

            module "tableau_backup_monitor" {
              source = "./mymodule"

              providers = {
                aws = aws
              }

            path_module = "./"
            naming_suffix                   = "apps-preprod-dq"
            namespace                       = "preprod"
            }
        """
        self.runner = Runner(self.snippet)
        self.result = self.runner.result

    def test_name_suffix_int_tab_lambda_monitor(self):
        self.assertEqual(
            self.runner.get_value("module.tableau_backup_monitor.aws_lambda_function.int_tab_monitor", "tags"),
            {"Name": "lambda-int-tab-monitor-apps-preprod-dq"})

    def test_name_suffix_ext_tab_lambda_monitor(self):
        self.assertEqual(
            self.runner.get_value("module.tableau_backup_monitor.aws_lambda_function.ext_tab_monitor", "tags"),
            {"Name": "lambda-ext-tab-monitor-apps-preprod-dq"})
