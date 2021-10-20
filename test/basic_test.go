package test

import (
	"context"
	"log"
	"os"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/eks"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestTerraformBasicExample(t *testing.T) {
	t.Parallel()

	awsProfile := os.Getenv("AWS_PROFILE")
	require.NotEmpty(t, awsProfile)

	awsRegion := os.Getenv("AWS_DEFAULT_REGION")
	require.NotEmpty(t, awsRegion)

	vpcName := os.Getenv("SIMPLE_EKS_TEST_VPC_NAME")
	require.NotEmpty(t, vpcName)

	cluster := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/basic",
		Vars: map[string]interface{}{
			"aws_profile": awsProfile,
			"aws_region":  awsRegion,
			"vpc_name":    vpcName,
		},
		NoColor: true,
	})

	addons := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/basic/post-setup",
		Vars: map[string]interface{}{
			"aws_region": awsRegion,
		},
		NoColor: true,
	})

	// Defer functions are executed in Last In, First Out order
	defer terraform.Destroy(t, cluster)
	defer terraform.Destroy(t, addons)

	terraform.InitAndApply(t, cluster)
	terraform.InitAndApply(t, addons)

	checkNodeGroupExists(t)
}

func checkNodeGroupExists(t *testing.T) {
	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		log.Fatal(err)
	}

	client := eks.NewFromConfig(cfg)

	output, err := client.ListNodegroups(
		context.TODO(),
		&eks.ListNodegroupsInput{
			ClusterName: aws.String("simple-eks-integration-test-for-eks-addons"),
		},
	)

	if err != nil {
		log.Fatal(err)
	}

	assert.Len(t, output.Nodegroups, 1)
	assert.Equal(t, "on-demand", output.Nodegroups[0])
}
