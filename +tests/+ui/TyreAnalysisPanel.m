classdef TyreAnalysisPanel < matlab.unittest.TestCase
    %Unit tests for TYREANALYSISPANEL class
    
    properties
        TestFigure matlab.ui.Figure
        TestObject ui.TyreAnalysisPanel
    end
    
    methods (TestClassSetup)
        function createTestObject(testCase)
            f = uifigure('Position', [0 50 800 500]);
            g = uigridlayout(f, 'ColumnWidth', {'1x'}, 'RowHeight', {'1x'});
            p = ui.TyreAnalysisPanel(g);
            testCase.TestFigure = f;
            testCase.TestObject = p;
        end
    end
    
    methods (TestClassTeardown)
        function deleteTestObject(testCase)
%             delete(testCase.TestFigure)
        end
    end
    
    methods (Test)
        function testChangeTyreModel(testCase)
            file = fullfile('doc','examples','fsae-ttc-data',...
                'fsaettc_obfuscated.tir');
            model = magicformula.v62.Model(file);
            p = testCase.TestObject;
            e = events.ModelChangedEventData(model);
            notify(p, 'TyreModelChanged', e)
%             pause(5)
        end
    end
end

