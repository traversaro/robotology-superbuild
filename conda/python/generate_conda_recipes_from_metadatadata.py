import argparse
import jinja2
import os
import string
import yaml
import shutil

def dir_path(string):
    if os.path.isdir(string):
        return string
    else:
        raise NotADirectoryError(string)

def main():

    # Parse parameters
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--metametadata", type=str, help="metametadata .yaml file")
    parser.add_argument("-o", "--recipes_dir", type=dir_path, help="directory of generated recipes directory")
    args = parser.parse_args()

    # Get recipe templates
    recipe_template_dir = os.path.realpath(os.path.dirname(os.path.abspath(__file__)) + "/../recipe_template");
    recipe_template_files = [f for f in os.listdir(recipe_template_dir) if os.path.isfile(os.path.join(recipe_template_dir, f))]

    # Prepare Jinja templates
    file_loader = jinja2.FileSystemLoader(recipe_template_dir)
    env = jinja2.Environment(loader=file_loader)
        # Load metametadata
    metametadata = yaml.load(open(args.metametadata), Loader=yaml.FullLoader)

    for pkg in metametadata['conda-packages-metametadata']:
        print("generate_conda_recipes_from_metadatadata: generate recipe for package {pkg}")
        pkg_info = metametadata['conda-packages-metametadata'][pkg]
        recipe_dir = os.path.join(os.path.realpath(args.recipes_dir), pkg_info['name'])
        shutil.rmtree(recipe_dir, ignore_errors=True)
        os.mkdir(recipe_dir)
        for template_file in recipe_template_files:
            template = env.get_template(template_file)
            template_output = template.render(pkg_info)
            with open(os.path.join(recipe_dir, template_file), 'w') as f:
                f.write(template_output)

if __name__ == '__main__':
    main()
