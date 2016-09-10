require_relative '../lib/iroha/builder/simple'

include Iroha::Builder::Simple

design = IDesign :design do
  IModule :m_top do
    ITable :tab_top do
      SubModuleTaskCall :task, nil
      IState            :st10
      st10.on {
        task.call
      }
    end
    IModule :m_sub do
      ITable :tab_sub do
        SubModuleTask   :task
        IState          :st20
        @owner_design.m_top.tab_top.task.callee(task)
        st20.on {
          task.entry
        }
      end
    end
  end
end

puts design.to_exp("")
