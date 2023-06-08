import coremltools

# Load the Core ML model
model = coremltools.models.MLModel('YOLOv3TinyFP16.mlmodel')

# Generate Swift code
swift_code = coremltools.converters.convert(model, 'swift')

# Save the Swift code to a file
with open('YourModel.swift', 'w') as file:
    file.write(swift_code)

