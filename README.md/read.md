详情可见：https://blog.csdn.net/2301_79615277?spm=1011.2266.3001.5343
​项目总览
这是一个基于C#的WinForms项目——个人经济管理系统。它能帮助用户高效管理日常收支，提供数据统计和预算管理功能。

项目准备四大支柱
1.项目框架——设计模式

2.功能灵魂——算法

3.数据设计——数据结构

4.用户体验——交互流程

架构理念
分层设计：
用户界面层 → 可视化选项
     ↓
业务逻辑层 → 验证业务规则
     ↓  
数据接口层 →  抽象大纲
     ↑
数据实现层 → 具体实现
     ↓
数据存储层 → 物理存储

设计模式：
类桥接模式，依赖倒置原则

易于维护：
接口与实现分离，适合中小项目

技术栈
语言：C#

框架：.NET 8.0

UI框架：Console/WinForms

数据存储：Json文件序列化

开发工具：Visual Studio/VS Code

核心功能
功能模块	具体功能	技术亮点
交易管理	添加收入/支出，编辑/删除交易，显示余额	CRUD操作，数据验证
数据查询	可按类别/时间/类型查询或一键查询所有交易	LINQ查询，算法优化
统计报表	月度收支统计，年度趋势报告，分类占比分析，余额显示	数据聚合算法
预算管理	预算设置/删除，超支预警，使用率监控	业务逻辑算法
数据持久化	自动保存，数据导出，备份恢复	文件IO，序列化
快速开始
环境要求
.NET 8.0 SDK

Visual Studio/VS Code

运行步骤
1.克隆项目

git clone https://github.com/M-998-hub/PersonalFinanceManager.git

2.打开解决方案

cd PersonalFinanceManager
dotnet run --project PersonalFinanceManager.csproj

项目结构可视化
PersonalFinanceManager/ (解决方案根目录)
├── PersonalFinanceManager/ (核心项目)
│   ├── Data Access/
│   │   ├── IDataRepository.cs
│   │   └── JsonFileRepository.cs
│   ├── Data Models/
│   │   ├── Budget.cs
│   │   ├── BudgetAlert.cs
│   │   ├── ReportModels.cs
│   │   ├── Transaction.cs
│   │   └── TransactionType.cs
│   ├── DataFiles/
│   │   ├── budgets.json
│   │   └── transactions.json
│   ├── Services/
│   │   └── FinanceManager.cs
│   ├── UI/
│   │   └── ConsoleInterface.cs
│   ├── Program.cs
│   └── PersonalFinanceManager.csproj
└── README.md

开发特色
架构设计
表示层 (Presentation) ← 业务层 (Business) ← 数据层 (Data)
     ↓                      ↓                     ↓
Console/WinForms        FinanceManager        File/Database

清晰分层：严格的层级分离，便于维护和测试

依赖注入：松耦合设计，易于拓展

接口抽象：数据访问层抽象，支持多种存储方式

技术亮点
OOP设计：清晰的类职责分离，高内聚，低耦合

算法应用：统计计算，数据聚合，趋势分析

LINQ查询：高效的数据筛选和统计

异常处理：完善的错误处理和用户反馈

业务理解
需求分析：作为一个轻量化应用，有大学生，上班族等广泛受众群体

交互设计：简洁直观的界面和操作

拓展思考：账号支持，数据加密，云同步等未来方向

工具准备
工具使用：
Git，VScode

开发环境：
VScode + C#拓展

.NET SDK

Git（版本控制）

​
