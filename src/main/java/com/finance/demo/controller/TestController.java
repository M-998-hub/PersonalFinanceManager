// src/main/java/demo/controller/TestController.java
package demo.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class TestController {

    @GetMapping("/test/config")
    @ResponseBody
    public String testConfig() {
        return """
            <h3>配置测试</h3>
            <ul>
                <li><a href="/css/global.css">CSS文件测试</a></li>
                <li><a href="/js/utils.js">JS文件测试</a></li>
                <li><a href="/test.html">静态页面测试</a></li>
            </ul>
            """;
    }
}