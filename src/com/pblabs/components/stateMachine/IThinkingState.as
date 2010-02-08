package com.pblabs.components.stateMachine
{
    public interface IThinkingState extends IState
    {
        function getTimeForNextTick(fsm:IMachine):int;
    }
}