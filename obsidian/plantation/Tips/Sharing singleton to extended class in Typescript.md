This is a base abstract class on that can be extended for a simple shareable singleton setup:

```ts
/// The base repository class
export abstract class BaseRepository<T extends BaseRepository<T>> {
  /// The instances of the repository
  protected static _instances: Map<string, unknown> = new Map();

  /// The database
  protected db: DatabaseClient;

  /// The constructor
  constructor() {
    this.db = getDatabase();
  }

  /// Returns an instance of the repository
  public static instance<T extends BaseRepository<T>>(this: new () => T): T {
    const className = this.name;
    const instances = BaseRepository._instances;

    if (!instances.has(className)) {
      instances.set(className, new this());
    }

    return instances.get(className) as T;
  }
}
```

To use this:

```ts
class UserRepo extends BaseRepository<UserRepo> {}

const user = UserRepo.instance();
```
