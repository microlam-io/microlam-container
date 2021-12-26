FROM ghcr.io/graalvm/graalvm-ce:java11-21
RUN microdnf install -y zip
RUN gu install native-image
RUN curl -4 -L https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie -o /usr/bin/aws-lambda-rie
RUN chmod 755 /usr/bin/aws-lambda-rie
