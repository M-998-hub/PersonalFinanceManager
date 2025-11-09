using PersonalFinanceManager.Data;
using PersonalFinanceManager.Services;
using PersonalFinanceManager.UI;

namespace PersonalFinanceManager
{
    class Program
    {
        static void Main(string[] args)
        {
            // 创建数据仓库
            IDataRepository repository = new JsonFileRepository();
            
            // 创建业务逻辑
            FinanceManager manager = new FinanceManager(repository);
            
            // 创建用户界面并运行
            ConsoleInterface ui = new ConsoleInterface(manager);
            ui.Run();

            // 显示主菜单
            ui.ShowMainMenu();
            
            System.Console.WriteLine("项目结构创建成功！按任意键退出...");
            System.Console.ReadKey();
        }
    }
}