//for(key in System.Env.Keys) print(key)

for(key in System.Properties.Keys) print(key)

for(key in {
  "user.dir",
  "java.runtime.name"
}) {
  print("${key} = ${System.Properties.get(key)}")
}