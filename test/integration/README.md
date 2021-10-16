# Integration test

A _manual_ integration test.

### Instructions

1. Open a new terminal and run`$ ./run.sh`
2. Open a separate terminal and run `echo '{"timestamp": 1634386250, "message":"hello!"}\n' | netcat 127.0.0.1 5170`
3. Somehow flush data (I simply stop the docker container)
4. Verify out data (It should look like `out.YYYYMMDD_N.log`) with `protoc`
   1. `protoc --decode_raw < out.YYYYMMDD_N.log`
   2. `cat out.YYYYMMDD_N.log | protoc --decode=Log --proto_path=. log.proto`
