# ActiveObject
一. 支持的类型
1. 支持的属性类型: 整形, 浮点型, NSNumber, NSString, NSArray, NSDictionary, Record
2. 若属性是NSArray 可以存 Record (但是必须调用 arrayTransformerWithModelClass: forKeyPath: 指定NSArray存的是那个Class, 支持嵌套), 也可以存 NSNumber, NSString, NSArray, NSDictionary
3. NSDictionary(不能包含 Record对象)
4.支持嵌套

二. 支持异步

三. 支持迁移

四. 支持加密

五.支持sqlite3 常用操作
