COMMON_CONFIG_FILE = "../release-configs/{{ENVIRONMENT}}/common-terraform.tfvars"
INFRA_CONFIG_FILE = "../release-configs/{{ENVIRONMENT}}/infrastructure-terraform.tfvars"


class ConfigReader:

    def __init__(self, environment) -> None:
        self.environment = environment

    def get_line(self, file_name, pattern):
        with open(file_name) as file:
            for line in file:
                if pattern in line:
                    return line

    def get_infra_config_file_path(self):
        return INFRA_CONFIG_FILE.replace("{{ENVIRONMENT}}", self.environment)

    def get_common_config_file_path(self):
        return COMMON_CONFIG_FILE.replace("{{ENVIRONMENT}}", self.environment)

    def get_value(self, line):
        return line.split("=")[-1].strip().strip('"').strip("'")

    def get_value_from_key(self, file_name, key):
        line = self.get_line(file_name, key)
        return self.get_value(line)

    def get_region(self):
        path = self.get_common_config_file_path()
        return self.get_value_from_key(path, "region")

    def get_cluster_name(self):
        path = self.get_infra_config_file_path()
        return self.get_value_from_key(path, "eks_name")
