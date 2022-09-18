classdef FrictionEllipseAxes < matlab.unittest.TestCase
    %Unit tests for FRICTIONELLIPSEAXES class
    
    properties
        TestFigure matlab.ui.Figure
        TestObject ui.FrictionEllipseAxes
    end
    
    methods (TestClassSetup)
        function createTestObject(testCase)
            f = uifigure('Position', [0 50 400 400]);
            g = uigridlayout(f, 'ColumnWidth', {'1x'}, 'RowHeight', {'1x'});
            ax = ui.FrictionEllipseAxes(g);
            testCase.TestFigure = f;
            testCase.TestObject = ax;
        end
    end
    
    methods (TestClassTeardown)
        function deleteTestObject(testCase)
            delete(testCase.TestFigure)
        end
    end
    
    methods (Test)
        function testChangeTyreModel(testCase)
            file = fullfile('doc','examples','fsae-ttc-data',...
                'fsaettc_obfuscated.tir');
            model = magicformula.v62.Model(file);
            ax = testCase.TestObject;
            ax.Model = model;
            pause(5)
        end
    end
end

