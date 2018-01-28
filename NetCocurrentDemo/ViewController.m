//
//  ViewController.m
//  NetCocurrentDemo
//
//  Created by 冯振伟 on 2018/1/22.
//  Copyright © 2018年 冯振伟. All rights reserved.
//  网络并发

#import "ViewController.h"
typedef void(^FinishNetwork)();
@interface ViewController ()

@property (nonatomic, copy) FinishNetwork finishBolck;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor lightTextColor];
    
    [self netRequestBingFa];

    [self initData];

    [self initOpertion];

    [self initGCDBingFa];

    [self test];
    
    [self GCDTest];
}

/**
 网络并发
 */
- (void)netRequestBingFa {
    // 信号量
    dispatch_semaphore_t time = dispatch_semaphore_create(0);
    // 创建全局变量
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{
        NSLog(@"1");
        [self setFinishBolck:^{
            dispatch_semaphore_signal(time);
        }];
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"2");
        [self setFinishBolck:^{
            dispatch_semaphore_signal(time);
        }];
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"3");
        [self setFinishBolck:^{
            dispatch_semaphore_signal(time);
        }];
    });
    
    dispatch_group_notify(group, queue, ^{
        // 三个请求对应三次信号等待
        dispatch_semaphore_wait(time, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(time, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(time, DISPATCH_TIME_FOREVER);
    });
    
}

- (void)initData {
    // 创建信号量
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    // 创建全局并行
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{

        dispatch_semaphore_signal(semaphore);
        NSLog(@"yue");
        
    });
    dispatch_group_async(group, queue, ^{

        dispatch_semaphore_signal(semaphore);
        
                NSLog(@"duihuan11");
    });
    dispatch_group_async(group, queue, ^{

        dispatch_semaphore_signal(semaphore);
        
    });
    
    dispatch_group_notify(group, queue, ^{
        
        //更新UI操作
        NSLog(@"1__value: %@", semaphore);
        // 三个请求对应三次信号等待
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        //更新UI操作
        NSLog(@"2__value: %@", semaphore);
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        //更新UI操作
        NSLog(@"3__value: %@", semaphore);
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

        
        //在这里 进行请求后的方法，回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //更新UI操作
            NSLog(@"value: %@", semaphore);
        });
        
        
    });
}

/**
 线程池
 这个是在其他线程里面进行操作的
 */
- (void)initOpertion {
    // 创建其他线程
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation * bolckOperation = [NSBlockOperation blockOperationWithBlock:^{
        for (NSInteger i = 0; i<2; i++) {
            NSLog(@"%ld__%@", i, [NSThread currentThread]);
        }
    }];
    
    NSBlockOperation * blcokA = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"我是A");
    }];
    // 添加依赖 blcokA需要在bolckOperation操作完成之后才能进行
    [blcokA addDependency:bolckOperation];
    [queue addOperation:bolckOperation];
    [queue addOperation:blcokA];
    
}

/**
 GCD中使用dispatch_semaphore_t(信号量来实现控制并发)
 当信号量=0时, 该线程会阻塞, 只有当信号量大于0
 */
- (void)initGCDBingFa {
    dispatch_semaphore_t semphore = dispatch_semaphore_create(1);
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_async(group, queue, ^{
        dispatch_semaphore_wait(semphore, DISPATCH_TIME_FOREVER);
        NSLog(@"__1");
        dispatch_semaphore_signal(semphore);
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1* NSEC_PER_SEC)), queue, ^{
//            NSLog(@"1");
//            dispatch_semaphore_signal(semphore);
//        });
    });
    
    dispatch_group_async(group, queue, ^{
        dispatch_semaphore_wait(semphore, DISPATCH_TIME_FOREVER);
        NSLog(@"__2");
        dispatch_semaphore_signal(semphore);
    });
    
    dispatch_group_notify(group, queue, ^{
//        dispatch_semaphore_wait(semphore, DISPATCH_TIME_FOREVER);
    });
}

- (void)test {
    dispatch_group_t group = dispatch_group_create();
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(6);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (int i = 0; i < 4; i++)
    {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"当前线程%@", [NSThread currentThread]);
        dispatch_group_async(group, queue, ^{
            NSLog(@"+++%i__%@",i, [NSThread currentThread]);
            dispatch_semaphore_signal(semaphore);
        });
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
}

- (void)GCDTest {
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(1);
    dispatch_queue_t queue  = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
//        sleep(1);
        NSLog(@"==1");
        dispatch_semaphore_signal(sema);
    });
    
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        NSLog(@"==2");
        dispatch_semaphore_signal(sema);
    });
    
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        sleep(1);
        NSLog(@"==3");
        dispatch_semaphore_signal(sema);
    });
    
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        sleep(1);
        NSLog(@"==4");
        dispatch_semaphore_signal(sema);
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
