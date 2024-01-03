import datetime
import os
import cv2


TEMPLATE_FILE = 'sources_1/new/index2sprite.template.vhd'
OUTPUT_FILE = 'sources_1/new/index2sprite.vhd'
ASSETS_FOLDER = 'assets/'
REPLACE_PATTERN = '-- {{ cases }}'
DARK_THEME = False

def main():
    # Open template file
    with open(TEMPLATE_FILE, 'r') as f:
        template = f.read()

        # Get images in assets folder
        images = os.listdir(ASSETS_FOLDER)
        images = [i for i in images if i.endswith('.png')]
        images.sort()
        print("Converting {} images".format(len(images)))

        # Convert images to matrices of black & white pixels
        sprites = {}
        for direction in images:
            print("Converting", direction)
            # Load image
            img = cv2.imread(ASSETS_FOLDER + direction, cv2.IMREAD_GRAYSCALE)
            # Convert to black & white
            img[img < 128] = 0 if DARK_THEME else 1
            img[img >= 128] = 1 if DARK_THEME else 0

            # Reshape to horizontal vector
            img = img.reshape(1, -1)

            # Put in sprites
            name = direction.split('.')[0]
            sprites[name] = img
        
        # Generate VHDL code from sprites
        code = ''

        # Find intendation of REPLACE_PATTERN
        replace_pattern_line = next(line for line in template.split('\n') if REPLACE_PATTERN in line)

        # Calculate the indentation by counting the leading spaces
        replace_pattern_indent = len(replace_pattern_line) - len(replace_pattern_line.lstrip(' '))

        for name, sprite in sprites.items():
            spaces = " " * replace_pattern_indent
            code += "\n" + spaces + '"{}"'.format(''.join(map(str, sprite[0])))
            code += ' when "{}",'.format(name)

        
        # Replace template with generated code
        template = template.replace(REPLACE_PATTERN, code)

        # Write to output file
        with open(OUTPUT_FILE, 'w') as f:
            header = "----------------------------------\
                    \n-- GENERATED CODE\
                    \n-- Do not edit this file directly\
                    \n----------------------------------"
        
            date_now = datetime.datetime.now().strftime("%d/%m/%Y %H:%M:%S")
            header += "\n-- Generated on {}\n".format(date_now)

            f.write(header)
            f.write(template)


    


if __name__ == '__main__':
    main()
