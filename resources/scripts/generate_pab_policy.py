import click
import json
import os


@click.command()
@click.option('--policy_id', help='The ID of the policy (e.g., example-policy).', type=str, required=True)
@click.option('--project', help='The project ID (e.g., example-dev).', type=str, required=True)
@click.option('--description', help='The output file (e.g., example-policy.json).', type=str, required=False)
def generate_policy_json(policy_id, project, description):
    display_name = policy_id.replace('-', ' ').title()

    if not description:
        description = f'Policy {display_name}.'

    policy_json = {
        "description": description,
        "resources": [
            f"//cloudresourcemanager.googleapis.com/projects/{project}"
        ],
        "effect": "ALLOW"
    }

    output_dir = 'resources/pab-policies'
    os.makedirs(output_dir, exist_ok=True)

    try:
        with open(os.path.join(output_dir, 'project-access-policy.json'), 'w') as f:
            json.dump(policy_json, f, indent=2)
        print('Policy file "resources/pab-policies/project-access-policy.json" has been created successfully.')
    except Exception as e:
        print(f'Error writing to file: {e}')


if __name__ == '__main__':
    generate_policy_json()
