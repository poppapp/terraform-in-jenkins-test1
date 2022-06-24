resource "aws_emr_cluster" "cluster" {
  name          = "emr-test-arn"
  release_label = "emr-5.35.0"
  applications  = ["Spark"]
  termination_protection            = false
  keep_job_flow_alive_when_no_steps = false

  ec2_attributes {
    subnet_id                         = module.vpc.public_subnets[0]
    emr_managed_master_security_group = module.security_group.security_group_id
    emr_managed_slave_security_group  = module.security_group.security_group_id
    instance_profile                  = aws_iam_instance_profile.emr_profile.arn
  }

  master_instance_group {
    instance_type = "m4.large"
  }
  core_instance_group {
    instance_type  = "m4.large"
    #instance_count = 1

    ebs_config {
      size                 = "40"
      type                 = "gp2"
      volumes_per_instance = 1
    }
  }

  ebs_root_volume_size = 100

  tags = {
    role = "rolename"
    env  = "env"
  }

  service_role = aws_iam_role.iam_emr_service_role.arn
  
  step {
      name              = "Run script"
      action_on_failure = "CONTINUE" #"TERMINATE_CLUSTER"
      hadoop_jar_step {
        jar  = "command-runner.jar"
        # args = ["spark-submit", "s3a://archive-emr-sparkcode/SparkCodeTerraformVersion.py", "job-xxx"]
        # args = ["spark-submit", "s3://gluelab-s3-archive/spark_job_for_test.py", "job-xxx", "--numround", "10000"]
        #2BReset (spark.yarn.submit.waitAppCompletion=true)
        # args = ["spark-submit","--deploy-mode","cluster","--master","yarn","--conf","spark.yarn.submit.waitAppCompletion=true", 
        # "s3://gluelab-s3-archive/spark_job_for_test.py","--numround","20000"]
        args = ["spark-submit","--deploy-mode","cluster","--master","yarn","--conf","spark.yarn.submit.waitAppCompletion=true", 
        "s3://gluelab-s3-archive/spark_job_for_test4.py","--numround","3"]
      }
    }

  log_uri = "s3://kpn-emr-log/logs/" 
}


resource "aws_emr_managed_scaling_policy" "samplepolicy" {
    cluster_id = aws_emr_cluster.cluster.id
    compute_limits {
      unit_type                       = "Instances"
      minimum_capacity_units          = 1
      maximum_capacity_units          = 4  # guess: total of 3 executors max
      #maximum_ondemand_capacity_units = 4
      #maximum_core_capacity_units     = 4
    }
}