import sys
import yaml
from config_reader.config_reader import ConfigReader

ENVIRONMENT = sys.argv[1]
OUTPUT = f"{sys.argv[2]}/hosts.aws_ec2.yaml"

def create_config_file(configs, path):
    with open(path, "w") as file:
        yaml.dump(configs, file)

if __name__ == "__main__":
    configReader = ConfigReader(ENVIRONMENT)
    region = configReader.get_region()
    cluster_name = configReader.get_cluster_name()

    configs = {
      "plugin": "amazon.aws.aws_ec2",
      "regions": [region],
      "compose": {
        "ansible_host": "instance_id"
      },
      "filters": {
        "tag:aws:eks:cluster-name": cluster_name,
        "instance-state-name" : "running"
      }
    }
    create_config_file(configs, OUTPUT)