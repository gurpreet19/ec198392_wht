TITLE Headless Upgrade deployment Batch file
@echo off
echo "Starting up the Headless Upgrade Deployment Batch application..."
java -Xms4096m -Xmx8192M -XX:+UseParallelGC -XX:+HeapDumpOnOutOfMemoryError -XX:PermSize=256M -XX:MaxPermSize=512M -Duser.timezone=UTC -jar headless-5.0.0.jar "DELTA_CREATION"
echo "Finished Headless Upgrade Deployment Batch application..."
