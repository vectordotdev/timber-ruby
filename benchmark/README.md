## Benchmarking & Performance

Timber was designed with an obsessive focus on performance and resource usage. In the `/benchmark` folder you'll find benchmarking tests.

The following results were run on a bare metal server in order to achieve consistent and repeatable results.

```console
+---------------------------+------------+-----------------+------------------+--------------+
|           Timber benchmarking. 10 requests per test. Times are "real" CPU time.            |
+---------------------------+------------+-----------------+------------------+--------------+
|                           | Total      | Per request avg | Per request diff | Per log line |
+---------------------------+------------+-----------------+------------------+--------------+
| Control                   | 0.00614905 | 0.00061491      |                  | 2.05e-05     |
| Timber probes only        | 0.00667906 | 0.00066791      | 5.3e-05          | 2.226e-05    |
| Timber probes and logging | 0.01047921 | 0.00104792      | 0.00038002       | 3.493e-05    |
+---------------------------+------------+-----------------+------------------+--------------+
```

1. `Control` - This is vanilla rails app without Timber installed.
2. `Timber probels only` - The same rails app but with the `Timber::Probes` installed, isolating probes performance.
3. `Timber probes and logging` - Testing the full Timber library, probes and adding context to each log line.

The benchmark can be run yourself via:

```console
$ appraisal ruby benchmark/rails_request.rb
```