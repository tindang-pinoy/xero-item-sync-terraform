FROM public.ecr.aws/lambda/python:3.14

# Copy the Requirements File to the lambda /var/task directory
COPY requirements.txt ${LAMBDA_TASK_ROOT}

# Copy the function folder code to the Lambda /var/task directory
COPY ./lambda_code/. ${LAMBDA_TASK_ROOT}

# Install the dependencies in the /var/task directory
RUN python3 -m pip install --upgrade -r ${LAMBDA_TASK_ROOT}/requirements.txt -t "${LAMBDA_TASK_ROOT}" -U --no-cache-dir

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD ["api_handler.lambda_handler"]